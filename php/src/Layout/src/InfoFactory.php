<?php

declare(strict_types=1);

namespace Layout;

use Psr\Container\ContainerInterface;

class InfoFactory
{
    public function __invoke(ContainerInterface $container) : Info
    {
        return new Info();
    }
}
