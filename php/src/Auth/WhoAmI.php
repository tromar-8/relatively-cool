<?php

declare(strict_types=1);

namespace Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Laminas\Diactoros\Response\JsonResponse;
use Mezzio\Authentication\UserInterface;

class WhoAmI implements RequestHandlerInterface
{
    public function handle(ServerRequestInterface $request) : ResponseInterface
    {
        $session = $request->getAttribute('session');
        $user = $session->get(UserInterface::class);
        if($user) {
            return new JsonResponse([
                'success' => true,
                'username' => in_array('guest', $user['roles']) ? null : $user['username'],
                'roles' => $user['roles'],
            ]);
        }
        $response = ['roles' => []];
        if($error = $request->getAttribute('error')) $response['error'] = $error;
        return new JsonResponse($response);
    }
}
