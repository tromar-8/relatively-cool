<?php

declare(strict_types=1);

namespace Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Psr\Http\Server\MiddlewareInterface;
use Doctrine\ORM\EntityManager;
use Laminas\Diactoros\Response\RedirectResponse;
use Laminas\Diactoros\Response\JsonResponse;

use Entity\User;

class Register implements MiddlewareInterface
{
    protected $orm;

    public function __construct(EntityManager $orm) {
        $this->orm = $orm;
    }

    public function validUser($string) {
        return $string != 'guest';
    }

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler) : ResponseInterface {
        $credential = $request->getParsedBody();
        if($credential['confirm'] == $credential['password']
           && $this->validUser($credential['username'])
           && !$this->orm->getRepository('Entity\User')->findOneBy(['name' => $credential['username']])) {
            $user = new User($credential);
            $this->orm->persist($user);
            $this->orm->flush();
        } else {
            $request = $request->withAttribute('error', 'Could not register.');
        }
        return $handler->handle($request);
    }
}
