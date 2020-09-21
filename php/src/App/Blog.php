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

use Entity\Blog as BlogEntity;

class Blog implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $orm = $request->getAttribute(EntityManager::class);
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        $blogRepo = $orm->getRepository('Entity\Blog');
        $success = false;
        switch($routeName) {
        case "blog.get":
            $blogs = $blogRepo->findAll();
            return new JsonResponse($blogs);
        case "blog.set":
            $author = $request->getAttribute('session')->get(UserInterface::class)['username'];
            $pe = $request->getParsedBody();
            $pe['author'] = $author;
            $pe['date'] = new \DateTime();
            if($blog = $blogRepo->findOneBy(['id' => $pe['id']])) {
                $blog->setInfo($pe);
            } else {
                $blog = new BlogEntity($pe);
            }
            $orm->persist($blog);
            $orm->flush();
            $success = true;
            break;
        case "blog.delete":
            $pe = $request->getParsedBody();
            if($blog = $blogRepo->findOneBy($pe)) {
                $orm->remove($blog);
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
