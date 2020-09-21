<?php

declare(strict_types=1);

namespace App;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Doctrine\ORM\EntityManager;

class OrmMiddleware implements MiddlewareInterface
{
    protected $orm;

    public function __construct(EntityManager $orm) {
        $this->orm = $orm;
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler) : ResponseInterface
    {
        return $handler->handle($request->withAttribute(EntityManager::class, $this->orm));
    }
}
