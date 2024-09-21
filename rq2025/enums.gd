extends Node

enum roles {
	AGGRESSOR,
	FLANKER,
	MINION,
	SNIPER,
	JACKAL
}

enum states {
	IDLE,
	SEEK,
	ENGAGE,
	ATTACK,
	DEFEND,
	FLY,
	JUMP,
	LAND,
	CLINCH,
	CLINCHED,
	FALL,
	KNOCKDOWN,
	STAGGER,
	DEAD
}

enum types {
	PLAYER,
	ENEMY,
	CPU,
	NPC
}
