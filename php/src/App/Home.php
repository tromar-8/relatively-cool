<?php

declare(strict_types=1);

namespace App;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;

class Home implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        return new JsonResponse([
            'php' => 'PHP is my 2nd least favourite programming language, thankfully the team behind the Laminas project (formally Zend Framework) have created incredibly awesome tools so I don\'t have to worry about the shortcomings of object orientated programming.'
        ]);
    }
}
