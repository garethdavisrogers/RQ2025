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
	CLINCH,
	STAGGER,
	DEAD
}
