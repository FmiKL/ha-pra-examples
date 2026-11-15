<?php

function request(string $method, string $path): array
{
    $context = stream_context_create([
        'http' => [
            'method' => $method,
            'ignore_errors' => true,
            'follow_location' => 0,
            'timeout' => 5,
        ],
    ]);

    $body = file_get_contents('http://127.0.0.1' . $path, false, $context);
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

[$status] = request('GET', '/');
check($status === 200, 'page accessible');

[$status, $body] = request('GET', '/health');
$before = json_decode($body, true, flags: JSON_THROW_ON_ERROR);
check($status === 200 && $before['status'] === 'ok', 'PHP et MySQL répondent');

[$writeStatus] = request('POST', '/');
[$status, $body] = request('GET', '/health');
$after = json_decode($body, true, flags: JSON_THROW_ON_ERROR);
check(
    $writeStatus === 303 && $status === 200 && $after['counter'] === $before['counter'] + 1,
    'écriture puis relecture dans MySQL',
);
