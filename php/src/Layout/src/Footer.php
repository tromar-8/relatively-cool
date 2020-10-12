<?php

declare(strict_types=1);

namespace Layout;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Router\RouteResult;
use Doctrine\ORM\EntityManager;

use Entity\FooterItem;

class Footer implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $orm = $request->getAttribute(EntityManager::class);
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        $repo = $orm->getRepository('Entity\Footer');
        $success = false;
        switch($routeName) {
        case "footer.get":
            return new JsonResponse($repo->findAll());
        case "footer.set":
            $pe = $request->getParsedBody();
            $pe['date'] = new \DateTime();
            if($item = $repo->findOneBy(['id' => $pe['id']])) {
                $item->setInfo($pe);
            } else {
                $item = new NavPages($pe);
            }
            $orm->persist($item);
            $orm->flush();
            $success = true;
            break;
        case "footer.delete":
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
