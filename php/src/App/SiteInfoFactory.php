<?php

declare(strict_types=1);

namespace App;

use Doctrine\ORM\EntityManager;
use Psr\Container\ContainerInterface;

class SiteInfoFactory
{
    public function __invoke(ContainerInterface $container) : SiteInfo
    {
        return new SiteInfo($container->get(EntityManager::class));
    }
}
