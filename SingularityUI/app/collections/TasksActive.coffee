Tasks = require './Tasks'
Task = require '../models/Task'

class TasksActive extends Tasks

    model: Task

    url: ->
        properties = [
            # offer
            'offer.hostname'

            # taskId
            'taskId'

            # mesosTask
            'mesosTask.resources'
        ]

        propertiesString = "?property=#{ properties.join('&property=') }"

        "#{ config.apiRoot }/tasks/active#{ propertiesString }"

    parse: (tasks) ->
        _.each tasks, (task, i) =>
            task.JSONString = utils.stringJSON task
            task.id = task.taskId.id
            task.requestId = task.taskId.requestId
            task.name = task.requestId
            task.resources = @parseResources task
            task.cpus = task.resources.cpus
            task.memoryMb = task.resources.memoryMb
            task.memoryHuman = if task.resources?.memoryMb? then "#{ task.resources.memoryMb }Mb" else ''
            task.host = task.offer.hostname?.split('.')[0]
            task.startedAt = task.taskId.startedAt
            task.startedAtHuman = utils.humanTimeAgo task.taskId.startedAt
            task.rack = task.taskId.rackId
            tasks[i] = task
            app.allTasks[task.id] = task

        tasks

    parseResources: (task) ->
        cpus: _.find(task.mesosTask.resources, (resource) -> resource.name is 'cpus')?.scalar?.value ? ''
        memoryMb: _.find(task.mesosTask.resources, (resource) -> resource.name is 'mem')?.scalar?.value ? ''

    comparator: 'startedAt'

module.exports = TasksActive