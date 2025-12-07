# Global.gd
extends Node

var is_the_quest_open_npc: bool = false
signal item_coletado(itens_restantes: int)
var quest_open = false
var quest_completed = []

# Variaveis para controlar missoes
var utha : bool = false
