<?php

function request(string $method, string $url): array
{
    $context = stream_context_create([
        'http' => [
            'method' => $method,
            'ignore_errors' => true,
            'follow_location' => 0,
            'timeout' => 5,
        ],
    ]);

    $body = file_get_contents($url, false, $context);
    $headers = http_get_last_response_headers();
    if ($body === false || !preg_match('/\s(\d{3})\s/', $headers[0] ?? '', $matches)) {
        throw new RuntimeException("L'application doit être démarrée.");
    }

    return [(int) $matches[1], $body];
}

function check(bool $success, string $message): void
{
    if (!$success) {
        throw new RuntimeException('Échec : ' . $message);
    }

    echo 'OK : ' . $message . PHP_EOL;
}

$baseUrl = $argv[1] ?? 'http://cloudflare';
$maintenance = ($argv[2] ?? '') === '--maintenance';

[$status] = request('GET', $baseUrl . '/');
check(
    $status === ($maintenance ? 503 : 200),
    $maintenance ? 'page en maintenance' : 'page accessible',
);

[$status, $body] = request('GET', $baseUrl . '/health');
$before = json_decode($body, true, flags: JSON_THROW_ON_ERROR);
check(
    $status === 200 && $before['status'] === 'ok' && $before['maintenance'] === $maintenance,
    'PHP et MySQL répondent dans le mode attendu',
);

[$writeStatus] = request('POST', $baseUrl . '/');
[$status, $body] = request('GET', $baseUrl . '/health');
$after = json_decode($body, true, flags: JSON_THROW_ON_ERROR);
check(
    $writeStatus === ($maintenance ? 503 : 303) && $status === 200
    && $after['counter'] === $before['counter'] + ($maintenance ? 0 : 1),
    $maintenance ? 'écriture bloquée' : 'écriture puis relecture dans MySQL',
);
