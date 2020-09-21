<?php

declare(strict_types=1);

namespace App;

use Doctrine\ORM\EntityManager;
use Psr\Container\ContainerInterface;

class OrmMiddlewareFactory
{
    public function __invoke(ContainerInterface $container) : OrmMiddleware
    {
        return new OrmMiddleware($container->get(EntityManager::class));
    }
}
