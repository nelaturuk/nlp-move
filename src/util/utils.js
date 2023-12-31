define([
  'q'
], function (
  Q) {
  function _getBasicModel (core, node) {
    return {
      name: core.getAttribute(node, 'name'),
      type: core.getAttribute(core.getMetaType(node), 'name'),
      path: core.getPath(node)
    }
  }

  function _basicModel2TransitionModel (core, node, path2Name, basicModel) {
    basicModel.src = path2Name[core.getPointerPath(node, 'src')]
    basicModel.dst = path2Name[core.getPointerPath(node, 'dst')]
    basicModel.guards = core.getAttribute(node, 'guards')
    basicModel.input = core.getAttribute(node, 'input')
    basicModel.output = core.getAttribute(node, 'output')
    basicModel.statements = core.getAttribute(node, 'statements')
    basicModel.tags = core.getAttribute(node, 'tags')
  }

  function _basicModel2CreateTransitionModel (core, node, path2Name, basicModel) {
    basicModel.src = path2Name[core.getPointerPath(node, 'src')]
    basicModel.dst = path2Name[core.getPointerPath(node, 'dst')]
    basicModel.guards = core.getAttribute(node, 'guards')
    basicModel.input = core.getAttribute(node, 'input')
    basicModel.output = core.getAttribute(node, 'output')
    basicModel.statements = core.getAttribute(node, 'statements')
    basicModel.tags = core.getAttribute(node, 'tags')
  }

  function getModelOfContract (core, contractNode) {
    const deferred = Q.defer()
    const model = {}
    const nameBasedSort = function (nodeA, nodeB) {
      const nameA = core.getAttribute(nodeA, 'name')
      const nameB = core.getAttribute(nodeB, 'name')
      if (nameA < nameB) {
        return -1
      } else if (nameA > nameB) {
        return 1
      }
      return 0
    }

    model.path = core.getPath(contractNode)
    model.name = core.getAttribute(contractNode, 'name')
    model.resources = core.getAttribute(contractNode, 'resources')
    model.imports = core.getAttribute(contractNode, 'imports')
    model.initial = ''
    model.transitions = []
    model.states = []
    model.finalStates = []
    model.createTransitions = []

    core.loadChildren(contractNode)
      .then(function (children) {
        let i; let childModel
        const path2Name = {}

        children.sort(nameBasedSort)

        for (i = 0; i < children.length; i += 1) {
          path2Name[core.getPath(children[i])] = core.getAttribute(children[i], 'name')
        }

        for (i = 0; i < children.length; i += 1) {
          childModel = _getBasicModel(core, children[i])
          // TODO not the nicest way and not too change-resistant
          switch (childModel.type) {
            case 'Transition':
              _basicModel2TransitionModel(core, children[i], path2Name, childModel)
              model.transitions.push(childModel)
              break
            case 'CreateTransition':
              _basicModel2CreateTransitionModel(core, children[i], path2Name, childModel)
              model.createTransitions.push(childModel)
              break
            case 'InitialState':
              model.initial = childModel.name
              break
            case 'State':
              model.states.push(childModel)
              break
            case 'FinalState':
              model.finalStates.push(childModel)
              break
          }
        }
        deferred.resolve(model)
      })
      .catch(deferred.reject)

    return deferred.promise
  }

  return {
    getModelOfContract: getModelOfContract
  }
})
