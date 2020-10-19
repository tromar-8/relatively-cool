<?php

declare(strict_types=1);

namespace Layout;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Router\RouteResult;
use Doctrine\ORM\EntityManager;

use Entity\NavPages;

class Nav implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $orm = $request->getAttribute(EntityManager::class);
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        $repo = $orm->getRepository('Entity\NavPages');
        $success = false;
        switch($routeName) {
        case "nav.get":
            return new JsonResponse($repo->findAll());
        case "nav.set":
            $pe = $request->getParsedBody();
            array_map(function($item) {
                $item = new NavPages($item);
                $orm->persist($item);
                $orm->flush();
            }, $pe);
            $success = true;
            break;
        case "nav.delete":
            $pe = $request->getParsedBody();
            if($item = $repo->findOneBy($pe)) {
                $orm->remove($item);
                $orm->flush();
                $success = true;
            }
            break;
        }
        return new JsonResponse([
            'success' => $success
        ]);
    }
}
