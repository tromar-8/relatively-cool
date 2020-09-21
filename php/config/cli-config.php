<?php
use Doctrine\ORM\Tools\Console\ConsoleRunner;
use Doctrine\ORM\EntityManager;
// replace with file to your own project bootstrap
$serviceManager = require_once 'config/container.php';

// replace with mechanism to retrieve EntityManager in your app
$entityManager = $serviceManager->get(EntityManager::class);

return ConsoleRunner::createHelperSet($entityManager);
