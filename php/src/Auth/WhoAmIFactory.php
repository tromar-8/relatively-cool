<?php

declare(strict_types=1);

namespace Auth;

use Doctrine\ORM\EntityManager;
use Psr\Container\ContainerInterface;

class WhoAmIFactory
{
    public function __invoke(ContainerInterface $container) : WhoAmI
    {
        return new WhoAmI($container->get(EntityManager::class));
    }
}
