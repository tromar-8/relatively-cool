<?php

declare(strict_types=1);

namespace App;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Router\RouteResult;
use Doctrine\ORM\EntityManager;

use Entity\Info;

class SiteInfo implements RequestHandlerInterface
{
    protected $orm;

    public function __construct(EntityManager $orm) {
        $this->orm = $orm;
    }

    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        if($routeName == 'info.set') {
            $info = $this->orm->find("Entity\Info", 1);
            $info->setInfo($request->getParsedBody());
            $this->orm->flush();
        }
        $info = $this->orm->find('Entity\Info', 1);

        return new JsonResponse(
            $info->toArray()
        );
    }
}
