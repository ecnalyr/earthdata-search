require 'spec_helper'

describe Echo::Client do
  let(:connection) { Object.new }

  context 'HTTP connection' do
    it 'is reused within a single thread' do
      expect(Echo::Client).to receive(:build_connection).once.and_return(connection)
      Echo::Client.connection
      Echo::Client.connection
    end

    it 'is not shared across threads' do
      expect(Echo::Client).to receive(:build_connection).twice.and_return(connection)

      thread = Thread.new {
        Echo::Client.connection
        Echo::Client.connection
      }
      thread.join(2)
      thread = Thread.new {
        Echo::Client.connection
        Echo::Client.connection
      }
      thread.join(2)
    end
  end

  context 'dataset searches' do
    let(:dataset_search_url) { "/catalog-rest/echo_catalog/datasets.json" }
    before { allow(Echo::Client).to receive(:connection).and_return(connection) }

    context 'using keywords' do
      it 'performs searches using partial keyword matches' do
        expect(connection).to receive(:get).with(dataset_search_url, keyword: "term%").and_return(:response)

        response = Echo::Client.get_datasets(keywords: "term")
        expect(response.faraday_response).to eq(:response)
      end

      it 'partially matches any word in the keyword query' do
        expect(connection).to receive(:get).with(dataset_search_url, keyword: "term1% term2%").and_return(:response)

        response = Echo::Client.get_datasets(keywords: "term1 term2")
        expect(response.faraday_response).to eq(:response)
      end

      it 'collapses whitespace in the keyword query' do
        expect(connection).to receive(:get).with(dataset_search_url, keyword: "term1% term2%").and_return(:response)

        response = Echo::Client.get_datasets(keywords: "  term1\t term2 \n")
        expect(response.faraday_response).to eq(:response)
      end

      it 'escaped catalog-rest reserved characters in the keyword query' do
        expect(connection).to receive(:get).with(dataset_search_url, keyword: "cloud\\_cover\\_\\%%").and_return(:response)

        response = Echo::Client.get_datasets(keywords: "cloud_cover_%")
        expect(response.faraday_response).to eq(:response)
      end
    end

    context 'by spatial point' do
      it 'searches the catalog using a "point" filter' do
        expect(connection).to receive(:get).with(dataset_search_url, point: "10.0,20.0").and_return(:response)

        response = Echo::Client.get_datasets(spatial: "point:10,20")
        expect(response.faraday_response).to eq(:response)
      end

      it 'moves longitudes to within [-180...180]' do
        expect(connection).to receive(:get).with(dataset_search_url, point: "90.0,0.0").and_return(:response)

        response = Echo::Client.get_datasets(spatial: "point:-270, 0")
        expect(response.faraday_response).to eq(:response)
      end

      it 'clips latitudes to [-90...90]' do
        expect(connection).to receive(:get).with(dataset_search_url, point: "10.0,90.0").and_return(:response)

        response = Echo::Client.get_datasets(spatial: "point:10,100")
        expect(response.faraday_response).to eq(:response)
      end

    end

    context 'by spatial bounding box' do
      it 'searches the catalog using a "bounding_box" filter' do
        expect(connection).to receive(:get).with(dataset_search_url, bounding_box: "10.0,20.0,30.0,40.0").and_return(:response)

        response = Echo::Client.get_datasets(spatial: "bounding_box:10,20:30,40")
        expect(response.faraday_response).to eq(:response)
      end

      it 'moves longitudes to within [-180...180]' do
        expect(connection).to receive(:get).with(dataset_search_url, bounding_box: "90.0,0.0,-90.0,10.0").and_return(:response)

        response = Echo::Client.get_datasets(spatial: "bounding_box:-270,0:270,10")
        expect(response.faraday_response).to eq(:response)
      end

      it 'clips latitudes to [-90...90]' do
        expect(connection).to receive(:get).with(dataset_search_url, bounding_box: "10.0,90.0,30.0,-90.0").and_return(:response)

        response = Echo::Client.get_datasets(spatial: "bounding_box:10,100:30,-110")
        expect(response.faraday_response).to eq(:response)
      end
    end
  end

  context 'dataset details' do
    let(:dataset_url) { "/catalog-rest/echo_catalog/datasets/C14758250-LPDAAC_ECS.echo10" }
    before { allow(Echo::Client).to receive(:connection).and_return(connection) }

    it 'with valid dataset ID' do
      expect(connection).to receive(:get).with(dataset_url, {}).and_return(:response)

      response = Echo::Client.get_dataset('C14758250-LPDAAC_ECS')
      expect(response.faraday_response).to eq(:response)
    end
  end

end