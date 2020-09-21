<?php

declare(strict_types=1);

namespace Auth;

use Psr\Container\ContainerInterface;

class DeniedFactory
{
    public function __invoke(ContainerInterface $container) : Denied
    {
        return new Denied();
    }
}
