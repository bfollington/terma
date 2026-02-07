Read and apply the guidance from @./subagent.md

# Report a bug

When we report a bug the subagent should take all of the context that we can pass to it from our conversation so far as relevant to the bug that I'm reporting. When we use this bug report command, the content of what I report is the observed behavior I'm seeing, but we also need to actually produce the steps that reliably could lead up to this or might reproduce this. Maybe some hypothesis of what could be done. Maybe a way to fix it. And we want to document the details of this bug in BUGS.md under a new heading. We want to make sure that this bug could be reproduced by somebody who was starting a blank session in this code base and trying to boot up and work on it. So we have to make sure we bring out all of our assumptions during the process of reporting it for later.

You can and should ask clarifying questions to gather more detail and narrow the report.

Enter planning mode and DO NOT fix the bug without asking the user first.
