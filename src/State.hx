class State {
	public var currentState:Void->Void;

	public function new(initialState:Void->Void) {
		this.currentState = initialState;
	}

	public function update() {
		if (this.currentState != null) {
			this.currentState();
		}
	}
}
