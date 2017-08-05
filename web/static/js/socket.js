import {Socket} from "phoenix"

let channel_token = window.document.querySelector("meta[name='channel_token']").content
let socket = new Socket("/socket", {params: {channel_token: channel_token}})
socket.connect()

let group = window.document.querySelector("meta[name='group']")
let statistic = window.document.querySelector("meta[name='statistic']")
if (group) {
  var total_members = 0
  var members = []

  let channel = socket.channel("group:" + group.content, {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on("total_members", payload => {
    console.log(payload)
    total_members = payload.total_members
  })

  let updateProgressBar = () => {
    var value = members.length * 100 / total_members
    var progressBar = window.document.querySelector("div.progress-bar")
    progressBar.setAttribute("aria-valuenow", value.toString());
    progressBar.innerHTML = value.toString() + "%"
    progressBar.style.width = value.toString() + "%"
  }

  let addRow = (statsRow) => {
    var table = window.document.getElementById("statisticsTable")
    var row = table.insertRow(1)
    var cell1 = row.insertCell(0)
    var cell2 = row.insertCell(1)
    cell1.innerHTML = statsRow[0]
    cell2.innerHTML = statsRow[1]
  }

  let updateGroupStatistics = () => {
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

  let updateTopicStatistics = () => {
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

  let updateOrganizerStatistics = () => {
    var statistics = members
    .map(m => m.memberships || {})
    .filter(m => (m.organizer || []).length > 0)
    .length

    statistics = [["organizer", statistics], ["total", total_members]]

    statistics.forEach(addRow);
  }

  let updateStatistics = () => {
    if (members.length < total_members) { return }

    if (statistic.content === "groups") {
      updateGroupStatistics()
    } else if (statistic.content === "topics") {
      updateTopicStatistics()
    } else if (statistic.content === "organizers") {
      updateOrganizerStatistics()
    }
  }

  channel.on("member", payload => {
    members.push(payload.member)
    updateProgressBar()
    updateStatistics()
  })
}

export default socket
