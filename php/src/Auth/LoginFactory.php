<?php

declare(strict_types=1);

namespace Auth;

use Mezzio\Authentication\Session\PhpSession;
use Psr\Container\ContainerInterface;

class LoginFactory
{
    public function __invoke(ContainerInterface $container) : Login
    {
        return new Login($container->get(PhpSession::class));
    }
}
