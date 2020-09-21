<?php

declare(strict_types=1);

namespace App;

use Psr\Container\ContainerInterface;

class ProjectFactory
{
    public function __invoke(ContainerInterface $container) : Project
    {
        return new Project();
    }
}
