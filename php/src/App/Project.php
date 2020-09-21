<?php

declare(strict_types=1);

namespace App;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Router\RouteResult;
use Doctrine\ORM\EntityManager;

use Entity\Project as ProjectEntity;

class Project implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $orm = $request->getAttribute(EntityManager::class);
        $routeName = $request->getAttribute(RouteResult::class)->getMatchedRouteName();
        $projectRepo = $orm->getRepository('Entity\Project');
        $success = false;
        switch($routeName) {
        case "project.get":
            $projects = $projectRepo->findAll();
            return new JsonResponse($projects);
        case "project.set":
            $pe = $request->getParsedBody();
            if($project = $projectRepo->findOneBy(['id' => $pe['id']])) {
                $project->setInfo($pe);
            } else {
                $project = new ProjectEntity($request->getParsedBody());
            }
            $orm->persist($project);
            $orm->flush();
            $success = true;
            break;
        case "project.delete":
            $pe = $request->getParsedBody();
            if($project = $projectRepo->findOneBy($pe)) {
                $orm->remove($project);
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
