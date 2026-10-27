TASK: Reply in chat to this message from a teammate, Priya:

"Re moving our job queue off Redis lists onto Postgres with SELECT ... FOR UPDATE SKIP LOCKED — three worries:
(1) throughput, we push maybe 400 jobs/s at peak, will PG keep up?
(2) we lose the visibility-timeout trick we use with RPOPLPUSH for crashed workers
(3) is this just resume-driven development?"

Facts you know: the Postgres instance is a db.r6g.xlarge, currently ~30% CPU. Nobody has benchmarked SKIP LOCKED on it. The current Redis setup lost about 1,200 jobs during the March failover because Redis persistence was off. Crashed-worker recovery in the new design would use a `locked_until` timestamp column that a sweeper resets. You don't know Priya's motives or who proposed the migration.
