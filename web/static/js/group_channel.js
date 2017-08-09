function updateProgressBar(members, total_members) {
  var value = (members.length * 100 / total_members).toFixed(2)
  var progressBar = window.document.querySelector("div.progress-bar")
  progressBar.setAttribute("aria-valuenow", value);
  progressBar.innerHTML = value + "%"
  progressBar.style.width = value + "%"
}

function updateStatistics(statistic, members, total_members) {
  if (members.length < total_members) { return }

  if (statistic === "groups") {
    updateGroupStatistics(members)
  } else if (statistic === "topics") {
    updateTopicStatistics(members)
  } else if (statistic === "organizers") {
    updateOrganizerStatistics(members, total_members)
  }
}

function updateGroupStatistics(members) {
  var statistics = members
  .map(m => m.memberships || {})
  .map(m => (m.member || []).concat(m.organizer || []))
  .reduce(( acc, cur ) => acc.concat(cur), [])
  .map(g => g.group.name)
  .reduce((allNames, name) => {
    if (name in allNames) {
      allNames[name]++;
    }
    else {
      allNames[name] = 1;
    }
    return allNames
  }, {})

  statistics = Object.keys(statistics)
    .map(key => [key, statistics[key]])
    .sort((a, b) => a[1] - b[1])

  statistics.forEach(addRow);
}

function updateTopicStatistics(members) {
  var statistics = members
  .map(m => m.topics || {})
  .reduce(( acc, cur ) => acc.concat(cur), [])
  .map(t => t.name)
  .reduce((allNames, name) => {
    if (name in allNames) {
      allNames[name]++;
    }
    else {
      allNames[name] = 1;
    }
    return allNames
  }, {})

  statistics = Object.keys(statistics)
    .map(key => [key, statistics[key]])
    .sort((a, b) => a[1] - b[1])

  statistics.forEach(addRow);
}

function updateOrganizerStatistics(members, total_members) {
  var statistics = members
  .map(m => m.memberships || {})
  .filter(m => (m.organizer || []).length > 0)
  .length

  statistics = [["organizer", statistics], ["total", total_members]]

  statistics.forEach(addRow);
}

function addRow(statsRow) {
  var table = window.document.getElementById("statisticsTable")
  var row = table.insertRow(1)
  var cell1 = row.insertCell(0)
  var cell2 = row.insertCell(1)
  cell1.innerHTML = statsRow[0]
  cell2.innerHTML = statsRow[1]
}

function initGroupChannel(socket) {
  let group = window.document.querySelector("meta[name='group']")
  if (group) {
    let statistic = window.document.querySelector("meta[name='statistic']").content
    var total_members = 0
    var members = []

    let channel = socket.channel("group:" + group.content, {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on("total_members", payload => {
      total_members = payload.total_members
    })

    channel.on("member", payload => {
      members.push(payload.member)
      updateProgressBar(members, total_members)
      updateStatistics(statistic, members, total_members)
    })

    channel.on("members", payload => {
      members = members.concat(payload.members)
      updateProgressBar(members, total_members)
      updateStatistics(statistic, members, total_members)
    })
  }
}

export default initGroupChannel
