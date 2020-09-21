<?php

declare(strict_types=1);

namespace Auth;

use Doctrine\ORM\EntityManager;
use Psr\Container\ContainerInterface;

class OrmAccessFactory
{
    public function __invoke(ContainerInterface $container) : OrmAccess
    {
        return new OrmAccess($container->get(EntityManager::class));
    }
}
