<?php

namespace Entity;

use Doctrine\ORM\Mapping as ORM;
use JsonSerializable;

/**
 * @ORM\Entity
 * @ORM\Table(name="blog")
 */
class Blog implements JsonSerializable
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
    protected $content;
    /**
     * @ORM\Column(type="date")
     */
    protected $date;
    /**
     * @ORM\Column(type="string")
     */
    protected $author;

    public function __construct($array) {
        $this->setInfo($array);
    }

    public function jsonSerialize() {
        return [
            'id' => $this->id,
            'content' => $this->content,
            'author' => $this->author,
            'date' => $this->date,
        ];
    }

    public function setInfo($array) {
        $this->id = $array['id'];
        $this->content = $array['content'];
        $this->author = $array['author'];
        $this->date = $array['date'];
    }
}
