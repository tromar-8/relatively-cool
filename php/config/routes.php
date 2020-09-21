<?php

declare(strict_types=1);

use Mezzio\Application;
use Mezzio\MiddlewareFactory;
use Psr\Container\ContainerInterface;

/**
 * Setup routes with a single request method:
 *
 * $app->get('/', App\Handler\HomePageHandler::class, 'home');
 * $app->post('/album', App\Handler\AlbumCreateHandler::class, 'album.create');
 * $app->put('/album/:id', App\Handler\AlbumUpdateHandler::class, 'album.put');
 * $app->patch('/album/:id', App\Handler\AlbumUpdateHandler::class, 'album.patch');
 * $app->delete('/album/:id', App\Handler\AlbumDeleteHandler::class, 'album.delete');
 *
 * Or with multiple request methods:
 *
 * $app->route('/contact', App\Handler\ContactHandler::class, ['GET', 'POST', ...], 'contact');
 *
 * Or handling all request methods:
 *
 * $app->route('/contact', App\Handler\ContactHandler::class)->setName('contact');
 *
 * or:
 *
 * $app->route(
 *     '/contact',
 *     App\Handler\ContactHandler::class,
 *     Mezzio\Router\Route::HTTP_METHOD_ANY,
 *     'contact'
 * );
 */
return static function (Application $app, MiddlewareFactory $factory, ContainerInterface $container) : void {
    $app->get('/', App\Home::class, 'home');
    $app->get('/info', App\SiteInfo::class, 'info.get');
    $app->post('/info', App\SiteInfo::class, 'info.set');
    $app->get('/project', App\Project::class, 'project.get');
    $app->post('/project', App\Project::class, 'project.set');
    $app->post('/project/delete', App\Project::class, 'project.delete');
    $app->get('/blog', App\Blog::class, 'blog.get');
    $app->post('/blog', App\Blog::class, 'blog.set');
    $app->post('/blog/delete', App\Blog::class, 'blog.delete');
    $app->post('/login', [Auth\Login::class, Auth\WhoAmI::class], 'login');
    $app->get('/logout', Auth\Logout::class, 'logout');
    $app->post('/register', [Auth\Register::class, Auth\Login::class, Auth\WhoAmI::class], 'register');
    $app->get('/whoami', Auth\WhoAmI::class, 'whoami');
    $app->get('/denied', Auth\Denied::class, 'denied');
};
