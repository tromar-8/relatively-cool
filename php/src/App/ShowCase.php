<?php

declare(strict_types=1);

namespace App;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Router\RouteResult;
use Mezzio\Authentication\UserInterface;
use Doctrine\ORM\EntityManager;

use Entity\ShowCase as ShowCaseEntity;

class ShowCase implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $orm = $request->getAttribute(EntityManager::class);
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        $repo = $orm->getRepository('Entity\ShowCase');
        $success = false;
        switch($routeName) {
        case "showcase.get":
            return new JsonResponse($repo->findAll());
        case "showcase.set":
            $pe = $request->getParsedBody();
            $pe['date'] = new \DateTime();
            if($item = $repo->findOneBy(['id' => $pe['id']])) {
                $item->setInfo($pe);
            } else {
                $item = new ShowCaseEntity($pe);
            }
            $orm->persist($item);
            $orm->flush();
            $success = true;
            break;
        case "showcase.delete":
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
