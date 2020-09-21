<?php

declare(strict_types=1);

namespace Auth;

use Psr\Container\ContainerInterface;

class LogoutFactory
{
    public function __invoke(ContainerInterface $container) : Logout
    {
        return new Logout();
    }
}
