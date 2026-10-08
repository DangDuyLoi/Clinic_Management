<?php
$user = App\Models\User::where('phone_number', '+84374244315')->first();
echo "FCM_TOKEN: " . $user->fcm_token . "\n";
