<?php

namespace Entity;

use Doctrine\ORM\Mapping as ORM;
use JsonSerializable;

/**
 * @ORM\Entity
 * @ORM\Table(name="nav_items")
 */
class NavPages implements JsonSerializable
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
    protected $text;
    /**
     * @ORM\Column(type="string")
     */
    protected $url;

    public function __construct($array) {
        setTitle($array['text']);
        setUrl($array['url']);
    }

    public function jsonSerialize() {
        return [
            'text' => $this->text,
            'url' => $this->url
        ];
    }

    public function setTitle($string) {
        $this->title = $string;
    }

    public function setUrl($string) {
        $this->url = $string;
    }
}
