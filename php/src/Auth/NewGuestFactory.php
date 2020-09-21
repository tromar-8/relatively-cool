<?php

declare(strict_types=1);

namespace Auth;

use Psr\Container\ContainerInterface;

class NewGuestFactory
{
    public function __invoke(ContainerInterface $container) : NewGuest
    {
        return new NewGuest();
    }
}
