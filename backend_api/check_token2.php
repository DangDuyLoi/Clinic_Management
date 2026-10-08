<?php
$users = App\Models\User::whereIn('phone_number', ['0374244315', '+84374244315'])->get();
foreach($users as $u) {
    echo "PHONE: " . $u->phone_number . " | FCM: " . $u->fcm_token . "\n";
}
