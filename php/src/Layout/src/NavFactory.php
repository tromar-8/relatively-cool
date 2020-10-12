<?php

declare(strict_types=1);

namespace Layout;

use Psr\Container\ContainerInterface;

class NavFactory
{
    public function __invoke(ContainerInterface $container) : Nav
    {
        return new Nav();
    }
}
