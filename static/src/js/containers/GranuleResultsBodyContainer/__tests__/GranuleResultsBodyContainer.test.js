import React from 'react'
import Enzyme, { shallow } from 'enzyme'
import Adapter from 'enzyme-adapter-react-16'
import { GranuleResultsBodyContainer } from '../GranuleResultsBodyContainer'
import GranuleResultsBody from '../../../components/GranuleResults/GranuleResultsBody'

Enzyme.configure({ adapter: new Adapter() })

function setup() {
  const props = {
    collections: {
      allIds: ['focusedCollection'],
      byId: {
        focusedCollection: {
          excludedGranuleIds: [],
          metadata: {}
        }
      }
    },
    focusedCollection: 'focusedCollection',
    granules: { value: 'granules' },
    granuleQuery: { pageNum: 1 },
    onChangeGranulePageNum: jest.fn(),
    onExcludeGranule: jest.fn()
  }

  const enzymeWrapper = shallow(<GranuleResultsBodyContainer {...props} />)

  return {
    enzymeWrapper,
    props
  }
}

describe('GranuleResultsBodyContainer component', () => {
  test('passes its props and renders a single GranuleResultsBody component', () => {
    const { enzymeWrapper } = setup()

    expect(enzymeWrapper.find(GranuleResultsBody).length).toBe(1)
    expect(enzymeWrapper.find(GranuleResultsBody).props().collectionId).toEqual('focusedCollection')
    expect(enzymeWrapper.find(GranuleResultsBody).props().granules).toEqual({ value: 'granules' })
    expect(enzymeWrapper.find(GranuleResultsBody).props().pageNum).toEqual(1)
    expect(typeof enzymeWrapper.find(GranuleResultsBody).props().waypointEnter).toEqual('function')
  })

  test('waypointEnter calls onChangeGranulePageNum', () => {
    const { enzymeWrapper, props } = setup()

    const granuleResultsBody = enzymeWrapper.find(GranuleResultsBody)

    granuleResultsBody.prop('waypointEnter')({ event: { type: 'scroll' } })

    expect(props.onChangeGranulePageNum.mock.calls.length).toBe(1)
    expect(props.onChangeGranulePageNum.mock.calls[0]).toEqual([2])
  })

  test('waypointEnter does not call onChangeGranulePageNum if there is no scroll event', () => {
    const { enzymeWrapper, props } = setup()

    const granuleResultsBody = enzymeWrapper.find(GranuleResultsBody)

    granuleResultsBody.prop('waypointEnter')({ event: null })

    expect(props.onChangeGranulePageNum.mock.calls.length).toBe(0)
  })
})
