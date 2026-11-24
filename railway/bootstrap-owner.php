<?php
// Creates the owner account on first boot, before the public port opens.
// Runs only while the users table is empty; afterwards it never changes an account.
// Exit codes: 0 = created or already present, 1 = failed (the start script then stops the service).

require '/app/vendor/autoload.php';
$app = require '/app/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Actions\Fortify\CreateNewUser;
use App\Models\User;
use Illuminate\Validation\ValidationException;

if (User::query()->exists()) {
    fwrite(STDOUT, "servas: an account already exists, skipping owner bootstrap\n");
    exit(0);
}

$name = getenv('SERVAS_ADMIN_NAME') ?: 'Admin';
$email = getenv('SERVAS_ADMIN_EMAIL') ?: '';
$password = getenv('SERVAS_ADMIN_PASSWORD') ?: '';

if ($email === '' || strlen($password) < 12) {
    fwrite(STDERR, "servas: SERVAS_ADMIN_EMAIL must be set and SERVAS_ADMIN_PASSWORD must be at least 12 characters\n");
    exit(1);
}

try {
    $user = app(CreateNewUser::class)->create([
        'name' => $name,
        'email' => $email,
        'password' => $password,
        'password_confirmation' => $password,
    ]);
} catch (ValidationException $e) {
    fwrite(STDERR, "servas: owner account rejected: " . json_encode($e->errors()) . "\n");
    exit(1);
}

fwrite(STDOUT, "servas: created owner account {$user->email}\n");
exit(0);
