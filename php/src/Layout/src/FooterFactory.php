<?php

declare(strict_types=1);

namespace Layout;

use Psr\Container\ContainerInterface;

class FooterFactory
{
    public function __invoke(ContainerInterface $container) : Footer
    {
        return new Footer();
    }
}
