# Postmortem Report: Half user call reconnecting

## Overview
**Date and Time**: [YYYY-MM-DD HH:MM (Time Zone)]  
**Duration**: [Total Duration of the Incident]  
**Affected Systems/Services**: User's call sessions 
**Incident Owner(s)**: Sam Chen, Devops 
**Severity Level**: High 

### Summary
One of the two nodes that manage the user's incoming calls got hardware issue

---

## Impact
**Business Impact**:
- Half of new incoming calls need retry to get connected 
- Most user session should be able to retry and got connected 
- No SLA breach 
- Company reputaion impact: minimal 

**Technical Impact**:
- As one of the instance was still able to handle all the call sessions, and running at 30~40% capacity,
  no performance impact observed, no downtime or data loss
- May have some phone call loss

---

## Timeline
| Time (UTC) | Event Description                                                        |
|------------|--------------------------------------------------------------------------|
| HH:MM      | Got some alerts regarding one of the hosts have no connection            |
| HH:MM      | Check the host health check, cpu, memory and disk spaces,  all look good |
| HH:MM      | Check the host log, got cuda error messages                              |
| HH:MM      | take the bad host from health check, all new calls go to working host    |
| HH:MM      | launch a new ec2 host, and provision the services to replace bad host    | 
| HH:MM      | the issue was fully resolved                                             |

---

## Root Cause Analysis
**Root Cause**:  
- one of the host got hardware issue, but health check still working fine, health check was not able to 
  reflect the service status, thus not able to block the new calls from coming to the bad host

**Contributing Factors**:
- health check was not able to reflect the service status
- system logs were not monitored

---

## Response and Resolution
1. **Detection**:
   - monitoring alerts showed hosts connection loosing balance, one host has no connections but other has many
2. **Escalation**:
   - Engineering manager to provide resouce on working with the issue
   - Customer Support manager to notify customers and make external communications
3. **Mitigation**:
   - add monitoring for system logs
   - add one more host to provide more redundancy as volume grows
4. **Resolution**:
   - manually failed health check to block connections come to bad host
   - replace the bad host and install services
   - enhance the health check to reflect the service status, not host status

---

## Lessons Learned
**What Worked Well**:
- monitoring regarding connection balancing worked well
- devops team response was quick
- automation on provision the new host worked well

**What Didn’t Work**:
- health check did not reflect service status
- system log was not monitored

---

## Preventative Measures
**Technical Improvements**:
- improve health check
- add system log monitoring
- add automation to auto provision new hosts if health check fails

**Process Improvements**:
- Add automation to provision new hosts on host failure
- Add log monitoring to existing alerts
- Enable/Disable a hot standby(redundant) host

**Action Items**:
| Action Item                                       | Owner          | Deadline       |
|---------------------------------------------------|----------------|----------------|
| improve health check                              | [Team/Person]  | [YYYY-MM-DD]   |
| add system log monitoring                         | [Team/Person]  | [YYYY-MM-DD]   |
| auto provision new hosts on host failure          | [Team/Person]  | [YYYY-MM-DD]   |
| add one a hot standby host to provide redundancy  | [Team/Person]  | [YYYY-MM-DD]   |

---

## Metrics
**Impact Metrics**:
- **Users Affected**: 50%
- **Calls dropped**: n/a
- **Downtime**: 0
- **Financial Impact**: 0
- **Future Financial Impact**: increase by 20% when adding a smaller hot standby host for redundancy

**Response Metrics**:
- **Time to Detect**: [Duration from start to detection]
- **Time to Resolve**: [Duration from detection to resolution]

---

## Follow-Up
follow up the above tickets on [YYYY-MM-DD]

**Next Retrospective Review Date**: [YYYY-MM-DD]

---

## Appendix
[Include any relevant logs, graphs, screenshots, or additional context.]

