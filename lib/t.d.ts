// utility types
type Literal = string | number | boolean | undefined | null | void | {};
type UnionToIntersection<U> = (U extends any ? (k: U) => void : never) extends (k: infer I) => void ? I : never;
type ArrayType<T> = T extends Array<infer U> ? U : never;

interface t {
	// lua types
	/** checks to see if `value` is not undefined */
	any: t.check<defined>;
	/** checks to see if `value` is a boolean */
	boolean: t.check<boolean>;
	/** checks to see if `value` is a thread */
	thread: t.check<thread>;
	/** checks to see if `value` is a function */
	callback: t.check<(...args: Array<unknown>) => unknown>;
	/** alias of t.callback */
	function: t.check<undefined>;
	/** checks to see if `value` is undefined */
	none: t.check<undefined>;
	/** alias of t.none */
	nil: t.check<undefined>;
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

	// roblox enum types
	/** checks to see if `value` is an Enum */
	Enum: t.check<Enum>;
	/** checks to see if `value` is an EnumItem */
	EnumItem: t.check<EnumItem>;
	/** checks if `value` is an EnumItem which belongs to `Enum`. */
	enum: <T extends { Name: string; }>(Enum: Enum.EnumType<T>) => t.check<T>;

	// type functions
	/** checks to see if `value == literalValue` */
	literal<T extends Array<Literal>>(this: void, ...args: T): t.check<ArrayType<T>>;
	/** Returns a t.union of each key in the table as a t.literal */
	keyOf: <T>(valueTable: T) => t.check<keyof T>;
	/** Returns a t.union of each value in the table as a t.literal */
	valueOf: <T>(valueTable: T) => T extends { [P in keyof T]: infer U } ? t.check<U> : never;
	/** checks to see if `value` is an integer */
	integer: t.check<number>;
	/** checks to see if `value` is a number and is more than or equal to `min` */
	numberMin: (min: number) => t.check<number>;
	/** checks to see if `value` is a number and is less than or equal to `max` */
	numberMax: (max: number) => t.check<number>;
	/** checks to see if `value` is a number and is more than `min` */
	numberMinExclusive: (min: number) => t.check<number>;
	/** checks to see if `value` is a number and is less than `max` */
	numberMaxExclusive: (max: number) => t.check<number>;
	/** checks to see if `value` is a number and is more than 0 */
	numberPositive: t.check<number>;
	/** checks to see if `value` is a number and is less than 0 */
	numberNegative: t.check<number>;
	/** checks to see if `value` is a number and `min <= value <= max` */
	numberConstrained: (min: number, max: number) => t.check<number>;
	/** checks to see if `value` is a number and `min < value < max` */
	numberConstrainedExclusive: (min: number, max: number) => t.check<number>;
	/** checks `t.string` and determines if value matches the pattern via `string.match(value, pattern)` */
	match: (pattern: string) => t.check<string>;
	/** checks to see if `value` is either nil or passes `check` */
	optional: <T>(check: t.check<T>) => t.check<T | undefined>;
	/** checks to see if `value` is a table and if its keys match against `check */
	keys: <T>(check: t.check<T>) => t.check<Map<T, unknown>>;
	/** checks to see if `value` is a table and if its values match against `check` */
	values: <T>(check: t.check<T>) => t.check<Map<unknown, T>>;
	/** checks to see if `value` is a table and all of its keys match against `keyCheck` and all of its values match against `valueCheck` */
	map: <K, V>(keyCheck: t.check<K>, valueCheck: t.check<V>) => t.check<Map<K, V>>;
	/** checks to see if `value` is a table and all of its keys match against `valueCheck` and all of its values are `true` */
	set: <T>(valueCheck: t.check<T>) => t.check<Set<T>>;
	/** checks to see if `value` is an array and all of its keys are sequential integers and all of its values match `check` */
	array: <T>(check: t.check<T>) => t.check<Array<T>>;
	/** ensures value is an array of a strict makeup and size */
	strictArray: <T extends Array<t.check<any>>>(...args: T) => t.check<{ [K in keyof T]: t.static<T[K]> }>;
	/** checks to see if `value` matches any given check */
	union: <T extends Array<t.check<any>>>(...args: T) => t.check<t.static<ArrayType<T>>>;
	/** checks to see if `value` matches all given checks */
	intersection: <T extends Array<t.check<any>>>(
	    ...args: T
	) => T[Exclude<keyof T, keyof Array<any> | "length">] extends infer U
	    ? (U extends any ? (k: U) => void : never) extends (k: t.check<infer I>) => void
		? t.check<I>
		: never
	    : never;
	/** checks to see if `value` matches a given interface definition */
	interface: <T extends { [index: string]: t.check<any> }>(
		checkTable: T,
	) => t.check<{ [P in keyof T]: t.static<T[P]> }>;
	/** checks to see if `value` matches a given interface definition with no extra members */
	strictInterface: <T extends { [index: string]: t.check<any> }>(
		checkTable: T,
	) => t.check<{ [P in keyof T]: t.static<T[P]> }>;
	/** ensure value is an Instance and it's ClassName matches the given ClassName */
	instanceOf<S extends keyof Instances>(this: void, className: S): t.check<Instances[S]>;
	instanceOf<S extends keyof Instances, T extends { [index: string]: t.check<any> }>(
		this: void,
		className: S,
		checkTable: T,
	): t.check<Instances[S] & { [P in keyof T]: t.static<T[P]> }>;
	/** ensure value is an Instance and it's ClassName matches the given ClassName by an IsA comparison */
	instanceIsA<S extends keyof Instances>(this: void, className: S): t.check<Instances[S]>;
	instanceIsA<S extends keyof Instances, T extends { [index: string]: t.check<any> }>(
		this: void,
		className: S,
		checkTable: T,
	): t.check<Instances[S] & { [P in keyof T]: t.static<T[P]> }>;
	/**
	 * Takes a table where keys are child names and values are functions to check the children against.
	 * Pass an instance tree into the function.
	 * If at least one child passes each check, the overall check passes.
	 *
	 * Warning! If you pass in a tree with more than one child of the same name, this function will always return false
	 */
	children: <T extends { [index: string]: t.check<any> }>(
		checkTable: T,
	) => t.check<Instance & { [P in keyof T]: t.static<T[P]> }>;
}

declare namespace t {
	/** creates a static type from a t-defined type */
	export type static<T> = T extends t.check<infer U> ? U : never;

	/** checks to see if `value` is a T */
	export type check<T> = (value: unknown) => value is T;
}

declare const t: t;
export { t };
