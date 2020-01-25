interface t {
	// lua types
	/** checks to see if `value` is not undefined */
	any: t.check<defined>;
	/** checks to see if `value` is a boolean */
	boolean: t.check<boolean>;
	/** checks to see if `value` is a thread */
	thread: t.check<thread>;
	/** checks to see if `value` is a Function */
	callback: t.check<Function>;
	/** checks to see if `value` is undefined */
	none: t.check<undefined>;
	/** checks to see if `value` is a number, will _not_ match NaN */
	number: t.check<number>;
	/** checks to see if `value` is NaN */
	nan: t.check<number>;
	/** checks to see if `value` is a string */
	string: t.check<string>;
	/** checks to see if `value` is an object */
	table: t.check<object>;
	/** checks to see if `value` is a userdata */
	userdata: t.check<object>;

	// roblox types
	/** checks to see if `value` is an Axes */
	Axes: t.check<Axes>;
	/** checks to see if `value` is a BrickColor */
	BrickColor: t.check<BrickColor>;
	/** checks to see if `value` is a CFrame */
	CFrame: t.check<CFrame>;
	/** checks to see if `value` is a Color3 */
	Color3: t.check<Color3>;
	/** checks to see if `value` is a ColorSequence */
	ColorSequence: t.check<ColorSequence>;
	/** checks to see if `value` is a ColorSequenceKeypoint */
	ColorSequenceKeypoint: t.check<ColorSequenceKeypoint>;
	/** checks to see if `value` is a DockWidgetPluginGuiInfo */
	DockWidgetPluginGuiInfo: t.check<DockWidgetPluginGuiInfo>;
	/** checks to see if `value` is a Faces */
	Faces: t.check<Faces>;
	/** checks to see if `value` is an Instance */
	Instance: t.check<Instance>;
	/** checks to see if `value` is a NumberRange */
	NumberRange: t.check<NumberRange>;
	/** checks to see if `value` is a NumberSequence */
	NumberSequence: t.check<NumberSequence>;
	/** checks to see if `value` is a NumberSequenceKeypoint */
	NumberSequenceKeypoint: t.check<NumberSequenceKeypoint>;
	/** checks to see if `value` is a PathWaypoint */
	PathWaypoint: t.check<PathWaypoint>;
	/** checks to see if `value` is a PhysicalProperties */
	PhysicalProperties: t.check<PhysicalProperties>;
	/** checks to see if `value` is a Random */
	Random: t.check<Random>;
	/** checks to see if `value` is a Ray */
	Ray: t.check<Ray>;
	/** checks to see if `value` is a Rect */
	Rect: t.check<Rect>;
	/** checks to see if `value` is a Region3 */
	Region3: t.check<Region3>;
	/** checks to see if `value` is a Region3int16 */
	Region3int16: t.check<Region3int16>;
	/** checks to see if `value` is a TweenInfo */
	TweenInfo: t.check<TweenInfo>;
	/** checks to see if `value` is a UDim */
	UDim: t.check<UDim>;
	/** checks to see if `value` is a UDim2 */
	UDim2: t.check<UDim2>;
	/** checks to see if `value` is a Vector2 */
	Vector2: t.check<Vector2>;
	/** checks to see if `value` is a Vector3 */
	Vector3: t.check<Vector3>;
	/** checks to see if `value` is a Vector3int16 */
	Vector3int16: t.check<Vector3int16>;
	/** checks to see if `value` is a RBXScriptSignal */
	RBXScriptSignal: t.check<RBXScriptSignal>;
	/** checks to see if `value` is a RBXScriptConnection */
	RBXScriptConnection: t.check<RBXScriptConnection>;

	/**
	 * checks to see if `value == literalValue`
	 */
	literal<T extends string | number | boolean | undefined>(this: void, literalValue: T): t.check<T>;
	literal<T extends Array<any>>(
		this: void,
		...args: T
	): T extends [infer A]
		? (value: unknown) => value is A
		: T extends [infer A, infer B]
		? t.check<A | B>
		: T extends [infer A, infer B, infer C]
		? t.check<A | B | C>
		: T extends [infer A, infer B, infer C, infer D]
		? t.check<A | B | C | D>
		: T extends [infer A, infer B, infer C, infer D, infer E]
		? t.check<A | B | C | D | E>
		: T extends [infer A, infer B, infer C, infer D, infer E, infer F]
		? t.check<A | B | C | D | E | F>
		: never;
	literal<T>(this: void, literalValue: T): (value: unknown) => value is T;

	/** Returns a t.union of each key in the table as a t.literal */
	keyOf: <T>(valueTable: T) => t.check<keyof T>;

	/** Returns a t.union of each value in the table as a t.literal */
	valueOf: <T>(valueTable: T) => T extends { [P in keyof T]: infer U } ? t.check<U> : never;

	/** checks to see if `value` is an integer */
	integer: (value: unknown) => value is number;
	/** checks to see if `value` is a number and is more than or equal to `min` */
	numberMin: (min: number) => (value: unknown) => value is number;
	/** checks to see if `value` is a number and is less than or equal to `max` */
	numberMax: (max: number) => (value: unknown) => value is number;
	/** checks to see if `value` is a number and is more than `min` */
	numberMinExclusive: (min: number) => (value: unknown) => value is number;
	/** checks to see if `value` is a number and is less than `max` */
	numberMaxExclusive: (max: number) => (value: unknown) => value is number;
	/** checks to see if `value` is a number and is more than 0 */
	numberPositive: (value: unknown) => value is number;
	/** checks to see if `value` is a number and is less than 0 */
	numberNegative: (value: unknown) => value is number;
	/** checks to see if `value` is a number and `min <= value <= max` */
	numberConstrained: (min: number, max: number) => (value: unknown) => value is number;
	/** checks to see if `value` is a number and `min < value < max` */
	numberConstrainedExclusive: (min: number, max: number) => (value: unknown) => value is number;
	/** checks `t.string` and determines if value matches the pattern via `string.match(value, pattern)` */
	match: (pattern: string) => t.check<string>;
	/** checks to see if `value` is either nil or passes `check` */
	optional: <T>(check: (value: unknown) => value is T) => t.check<T | undefined>;
	/** checks to see if `value` is a table and if its keys match against `check */
	keys: <T>(check: (value: unknown) => value is T) => t.check<Map<T, unknown>>;
	/** checks to see if `value` is a table and if its values match against `check` */
	values: <T>(check: (value: unknown) => value is T) => t.check<Map<unknown, T>>;
	/** checks to see if `value` is a table and all of its keys match against `keyCheck` and all of its values match against `valueCheck` */
	map: <K, V>(
		keyCheck: (value: unknown) => value is K,
		valueCheck: (value: unknown) => value is V
	) => t.check<Map<K, V>>;
	/** checks to see if `value` is an array and all of its keys are sequential integers and all of its values match `check` */
	array: <T>(check: (value: unknown) => value is T) => t.check<Array<T>>;

	/** checks to see if `value` matches any given check */
	union: <T extends Array<any>>(
		...args: T
	) => T extends [t.check<infer A>]
		? (value: unknown) => value is A
		: T extends [t.check<infer A>, t.check<infer B>]
		? t.check<A | B>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>]
		? t.check<A | B | C>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>, t.check<infer D>]
		? t.check<A | B | C | D>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>, t.check<infer D>, t.check<infer E>]
		? t.check<A | B | C | D | E>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>, t.check<infer D>, t.check<infer E>, t.check<infer F>]
		? t.check<A | B | C | D | E | F>
		: never;

	/** checks to see if `value` matches all given checks */
	intersection: <T extends Array<any>>(
		...args: T
	) => T extends [t.check<infer A>]
		? (value: unknown) => value is A
		: T extends [t.check<infer A>, t.check<infer B>]
		? t.check<A & B>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>]
		? t.check<A & B & C>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>, t.check<infer D>]
		? t.check<A & B & C & D>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>, t.check<infer D>, t.check<infer E>]
		? t.check<A & B & C & D & E>
		: T extends [t.check<infer A>, t.check<infer B>, t.check<infer C>, t.check<infer D>, t.check<infer E>, t.check<infer F>]
		? t.check<A & B & C & D & E & F>
		: never;

	/** checks to see if `value` matches a given interface definition */
	interface: <T extends { [index: string]: (value: unknown) => value is any }>(
		checkTable: T
	) => t.check<{ [P in keyof T]: t.static<T[P]> }>;

	/** checks to see if `value` matches a given interface definition with no extra members */
	strictInterface: <T extends { [index: string]: (value: unknown) => value is any }>(
		checkTable: T
	) => t.check<{ [P in keyof T]: t.static<T[P]> }>;

	instanceOf<S extends keyof Instances>(this: void, className: S): t.check<Instances[S]>;
	instanceOf<S extends keyof Instances, T extends { [index: string]: (value: unknown) => value is any }>(
		this: void,
		className: S,
		checkTable: T
	): t.check<Instances[S] & { [P in keyof T]: t.static<T[P]> }>;

	instanceIsA<S extends keyof Instances>(this: void, className: S): t.check<Instances[S]>;
	instanceIsA<S extends keyof Instances, T extends { [index: string]: (value: unknown) => value is any }>(
		this: void,
		className: S,
		checkTable: T
	): t.check<Instances[S] & { [P in keyof T]: t.static<T[P]> }>;

	children: <T extends { [index: string]: (value: unknown) => value is any }>(
		checkTable: T
	) => t.check<Instance & { [P in keyof T]: t.static<T[P]> }>;
}

declare namespace t {
	/** creates a static type from a t-defined type */
	export type static<T> = T extends t.check<infer U> ? U : never;

	/** checks to see if `value` is a T */
	export type check<T> = (value: unknown) => value is T;
}

declare const t: t;
export = t;
