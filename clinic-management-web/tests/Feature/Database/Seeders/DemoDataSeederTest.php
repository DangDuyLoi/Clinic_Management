<?php

namespace Tests\Feature\Database\Seeders;

use Database\Seeders\DemoDataSeeder;
use RuntimeException;
use Tests\TestCase;

class DemoDataSeederTest extends TestCase
{
    public function test_demo_seeder_is_rejected_in_production(): void
    {
        $this->app->detectEnvironment(static fn (): string => 'production');

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('Demo data cannot be seeded in production.');

        (new DemoDataSeeder)->run();
    }
}
