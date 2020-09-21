<?php

declare(strict_types=1);

namespace Auth;

use Doctrine\ORM\EntityManager;
use Psr\Container\ContainerInterface;

class RegisterFactory
{
    public function __invoke(ContainerInterface $container) : Register
    {
        return new Register($container->get(EntityManager::class));
    }
}
