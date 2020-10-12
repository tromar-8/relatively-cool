<?php

declare(strict_types=1);

namespace Layout;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Router\RouteResult;
use Doctrine\ORM\EntityManager;

class Info implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $orm = $request->getAttribute(EntityManager::class);
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        if($routeName == 'info.set') {
            $info = $orm->find("Entity\Info", 1);
            $info->setInfo($request->getParsedBody());
            $orm->flush();
        }
        $info = $orm->find('Entity\Info', 1);
        return new JsonResponse(
            $info->toArray()
        );
    }
}
