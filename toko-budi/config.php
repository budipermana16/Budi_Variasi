<?php
/**
 * config.php
 * Konfigurasi Koneksi Database menggunakan PDO (PHP Data Objects).
 * Pastikan ekstensi pdo_mysql aktif di php.ini Laragon.
 *
 * Lokasi: laragon/www/toko-budi/config.php
 */

// --- Pengaturan Pelaporan Error (Aktifkan saat development) ---
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// --- Pengaturan Zona Waktu ---
date_default_timezone_set('Asia/Jakarta');

// --- Konstanta Koneksi Database ---
define('DB_HOST', 'localhost');
define('DB_NAME', 'toko_budi');
define('DB_USER', 'root');
define('DB_PASS', '');          // Default Laragon: password kosong
define('DB_CHARSET', 'utf8mb4');

// --- Fungsi Singleton untuk mendapatkan koneksi PDO ---
// Menggunakan pola Singleton agar koneksi hanya dibuat satu kali
// per siklus request, efisien dan tidak membebani server.
function getPDO(): PDO
{
    static $pdo = null;

    if ($pdo === null) {
        $dsn = sprintf(
            'mysql:host=%s;dbname=%s;charset=%s',
            DB_HOST,
            DB_NAME,
            DB_CHARSET
        );

        $options = [
            // Lempar exception saat terjadi error SQL -> Lebih mudah di-debug
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            // Kembalikan hasil fetch sebagai array associative secara default
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            // Nonaktifkan emulasi prepared statements untuk keamanan penuh
            // Ini memastikan database benar-benar memproses query terpisah dari data
            PDO::ATTR_EMULATE_PREPARES   => false,
        ];

        try {
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            // Di production: log error, jangan tampilkan ke user
            error_log('[DB Error] ' . $e->getMessage());
            die(json_encode([
                'status'  => 'error',
                'message' => 'Koneksi database gagal. Hubungi administrator.'
            ]));
        }
    }

    return $pdo;
}

// --- Konstanta Keamanan Session ---
define('SESSION_NAME', 'toko_budi_sess');
define('APP_NAME', 'Sistem Inventory Budi Variasi');

// --- Mulai Session dengan Konfigurasi Aman ---
if (session_status() === PHP_SESSION_NONE) {
    session_name(SESSION_NAME);
    session_set_cookie_params([
        'lifetime' => 0,          // Session berakhir saat browser ditutup
        'path'     => '/',
        'secure'   => false,      // Ganti true jika pakai HTTPS di production
        'httponly' => true,       // Cegah akses via JavaScript (XSS protection)
        'samesite' => 'Strict',
    ]);
    session_start();
}
