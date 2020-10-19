<?php

namespace Entity;

use Doctrine\ORM\Mapping as ORM;
use JsonSerializable;

/**
 * @ORM\Entity
 * @ORM\Table(name="project")
 */
class ShowCase implements JsonSerializable
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue
     */
    protected $id;
    /**
     * @ORM\Column(type="string")
     */
    protected $name;
    /**
     * @ORM\Column(type="string")
     */
    protected $url;
    /**
     * @ORM\Column(type="text")
     */
    protected $description;

    public function __construct($array) {
        $this->setInfo($array);
    }

    public function jsonSerialize() {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'url' => $this->url,
            'description' => $this->description,
        ];
    }

    public function setInfo($array) {
        $this->id = $array['id'];
        $this->name = $array['name'];
        $this->url = $array['url'];
        $this->description = $array['description'];
    }
}
