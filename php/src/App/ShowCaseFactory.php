<?php

declare(strict_types=1);

namespace App;

use Psr\Container\ContainerInterface;

class ShowCaseFactory
{
    public function __invoke(ContainerInterface $container) : ShowCase
    {
        return new ShowCase();
    }
}
