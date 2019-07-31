/** checks to see if `value` is a T */
type check<T> = (value: unknown) => value is T;

interface t {
	// lua types
	/** checks to see if `value` is an any */
	any: (value: unknown) => value is any;
	/** checks to see if `value` is a boolean */
	boolean: (value: unknown) => value is boolean;
	/** checks to see if `value` is a thread */
	coroutine: (value: unknown) => value is thread;
	/** checks to see if `value` is a Function */
	callback: (value: unknown) => value is Function;
	/** checks to see if `value` is undefined */
	none: (value: unknown) => value is undefined;
	/** checks to see if `value` is a number, will _not_ match NaN */
	number: (value: unknown) => value is number;
	/** checks to see if `value` is NaN */
	nan: (value: unknown) => value is number;
	/** checks to see if `value` is a string */
	string: (value: unknown) => value is string;
	/** checks to see if `value` is an object */
	table: (value: unknown) => value is object;
	/** checks to see if `value` is a userdata */
	userdata: (value: unknown) => value is object;

	// roblox types
	/** checks to see if `value` is an Axes */
	Axes: (value: unknown) => value is Axes;
	/** checks to see if `value` is a BrickColor */
	BrickColor: (value: unknown) => value is BrickColor;
	/** checks to see if `value` is a CFrame */
	CFrame: (value: unknown) => value is CFrame;
	/** checks to see if `value` is a Color3 */
	Color3: (value: unknown) => value is Color3;
	/** checks to see if `value` is a ColorSequence */
	ColorSequence: (value: unknown) => value is ColorSequence;
	/** checks to see if `value` is a ColorSequenceKeypoint */
	ColorSequenceKeypoint: (value: unknown) => value is ColorSequenceKeypoint;
	/** checks to see if `value` is a DockWidgetPluginGuiInfo */
	DockWidgetPluginGuiInfo: (value: unknown) => value is DockWidgetPluginGuiInfo;
	/** checks to see if `value` is a Faces */
	Faces: (value: unknown) => value is Faces;
	/** checks to see if `value` is an Instance */
	Instance: (value: unknown) => value is Instance;
	/** checks to see if `value` is a NumberRange */
	NumberRange: (value: unknown) => value is NumberRange;
	/** checks to see if `value` is a NumberSequence */
	NumberSequence: (value: unknown) => value is NumberSequence;
	/** checks to see if `value` is a NumberSequenceKeypoint */
	NumberSequenceKeypoint: (value: unknown) => value is NumberSequenceKeypoint;
	/** checks to see if `value` is a PathWaypoint */
	PathWaypoint: (value: unknown) => value is PathWaypoint;
	/** checks to see if `value` is a PhysicalProperties */
	PhysicalProperties: (value: unknown) => value is PhysicalProperties;
	/** checks to see if `value` is a Random */
	Random: (value: unknown) => value is Random;
	/** checks to see if `value` is a Ray */
	Ray: (value: unknown) => value is Ray;
	/** checks to see if `value` is a Rect */
	Rect: (value: unknown) => value is Rect;
	/** checks to see if `value` is a Region3 */
	Region3: (value: unknown) => value is Region3;
	/** checks to see if `value` is a Region3int16 */
	Region3int16: (value: unknown) => value is Region3int16;
	/** checks to see if `value` is a TweenInfo */
	TweenInfo: (value: unknown) => value is TweenInfo;
	/** checks to see if `value` is a UDim */
	UDim: (value: unknown) => value is UDim;
	/** checks to see if `value` is a UDim2 */
	UDim2: (value: unknown) => value is UDim2;
	/** checks to see if `value` is a Vector2 */
	Vector2: (value: unknown) => value is Vector2;
	/** checks to see if `value` is a Vector3 */
	Vector3: (value: unknown) => value is Vector3;
	/** checks to see if `value` is a Vector3int16 */
	Vector3int16: (value: unknown) => value is Vector3int16;

	/**
	 * checks to see if `value == literalValue`\
	 * If your `literalValue` is not a primitive, use t.exactly instead.
	 */
	literal: <T extends string | number | boolean | undefined>(literalValue: T) => (value: unknown) => value is T;
	/** checks to see if `value == literalValue` */
	exactly: <T>(literalValue: T) => (value: unknown) => value is T;

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
	match: (pattern: string) => check<string>;
	/** checks to see if `value` is either nil or passes `check` */
	optional: <T>(check: (value: unknown) => value is T) => check<T | undefined>;
	/** checks to see if `value` is a table and if its keys match against `check */
	keys: <T>(check: (value: unknown) => value is T) => check<Map<T, unknown>>;
	/** checks to see if `value` is a table and if its values match against `check` */
	values: <T>(check: (value: unknown) => value is T) => check<Map<unknown, T>>;
	/** checks to see if `value` is a table and all of its keys match against `keyCheck` and all of its values match against `valueCheck` */
	map: <K, V>(
		keyCheck: (value: unknown) => value is K,
		valueCheck: (value: unknown) => value is V
	) => check<Map<K, V>>;
	/** checks to see if `value` is an array and all of its keys are sequential integers and all of its values match `check` */
	array: <T>(check: (value: unknown) => value is T) => check<Array<T>>;

	/** checks to see if `value` matches any given check */
	union: <T extends Array<any>>(
		...args: T
	) => T extends [check<infer A>]
		? (value: unknown) => value is A
		: T extends [check<infer A>, check<infer B>]
		? check<A | B>
		: T extends [check<infer A>, check<infer B>, check<infer C>]
		? check<A | B | C>
		: T extends [check<infer A>, check<infer B>, check<infer C>, check<infer D>]
		? check<A | B | C | D>
		: T extends [check<infer A>, check<infer B>, check<infer C>, check<infer D>, check<infer E>]
		? check<A | B | C | D | E>
		: T extends [check<infer A>, check<infer B>, check<infer C>, check<infer D>, check<infer E>, check<infer F>]
		? check<A | B | C | D | E | F>
		: never;

	/** checks to see if `value` matches all given checks */
	intersection: <T extends Array<any>>(
		...args: T
	) => T extends [check<infer A>]
		? (value: unknown) => value is A
		: T extends [check<infer A>, check<infer B>]
		? check<A & B>
		: T extends [check<infer A>, check<infer B>, check<infer C>]
		? check<A & B & C>
		: T extends [check<infer A>, check<infer B>, check<infer C>, check<infer D>]
		? check<A & B & C & D>
		: T extends [check<infer A>, check<infer B>, check<infer C>, check<infer D>, check<infer E>]
		? check<A & B & C & D & E>
		: T extends [check<infer A>, check<infer B>, check<infer C>, check<infer D>, check<infer E>, check<infer F>]
		? check<A & B & C & D & E & F>
		: never;

	/** checks to see if `value` matches a given interface definition */
	interface: <T extends { [index: string]: (value: unknown) => value is any }>(
		checkTable: T
	) => check<{ [P in keyof T]: t.static<T[P]> }>;

	/** checks to see if `value` matches a given interface definition with no extra members */
	strictInterface: <T extends { [index: string]: (value: unknown) => value is any }>(
		checkTable: T
	) => check<{ [P in keyof T]: t.static<T[P]> }>;

	instanceOf<S extends keyof Instances>(this: void, className: S): check<Instances[S]>;
	instanceOf<S extends keyof Instances, T extends { [index: string]: (value: unknown) => value is any }>(
		this: void,
		className: S,
		checkTable: T
	): check<Instances[S] & { [P in keyof T]: t.static<T[P]> }>;

	instanceIsA<S extends keyof Instances>(this: void, className: S): check<Instances[S]>;
	instanceIsA<S extends keyof Instances, T extends { [index: string]: (value: unknown) => value is any }>(
		this: void,
		className: S,
		checkTable: T
	): check<Instances[S] & { [P in keyof T]: t.static<T[P]> }>;

	children: <T extends { [index: string]: (value: unknown) => value is any }>(
		checkTable: T
	) => check<Instance & { [P in keyof T]: t.static<T[P]> }>;
}

declare namespace t {
	/** creates a static type from a t-defined type */
	export type static<T> = T extends check<infer U> ? U : never;
}

declare const t: t;
export = t;
