extends Node

#Statics is simply a reference to unchanging data formats like role or state

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
