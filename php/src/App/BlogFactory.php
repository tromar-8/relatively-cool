<?php

declare(strict_types=1);

namespace App;

use Psr\Container\ContainerInterface;

class BlogFactory
{
    public function __invoke(ContainerInterface $container) : Blog
    {
        return new Blog();
    }
}
